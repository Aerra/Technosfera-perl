package fastpaste;
use Dancer2;
use utf8;
use Dancer2::Plugin::Database;
use Dancer2::Plugin::CSRF;
use Digest::CRC qw/crc64/;
use HTML::Entities;

our $VERSION = '0.1';

my $upload_dir = 'paste';

sub get_upload_dir {
	return config->{appdir} . '/' . $upload_dir . '/';
}

sub delete_entry {
	my $id = shift;
	database->do('DELETE FROM paste WHERE id = cast(? as signed)', {}, $id);
	unlink get_upload_dir . $id;
}

get qr{^/([a-f0-9]{16})$} => sub {
	unless (session('user')) {
		redirect '/auth';
	}
	my ($id)=splat;
	$id = unpack 'Q', pack 'H*', $id;
	my $sth = database->prepare('SELECT cast(id as unsigned) as id, 
		create_time, unix_timestamp(expire_time) as expire_time, title, 
		user_id, friends FROM paste where id = cast(? as signed)');
	unless ($sth->execute($id)) {
		response->status(404);
		return template 'index' => {err => ['Note not found'], user_id => get_csrf_token()};
	}
	my $db_res = $sth->fetchrow_hashref();
	if ($db_res->{expire_time} and $db_res->{expire_time}<time())
	{
		delete_entry($id);
		response->status(404);
		return template 'index' => {err => ['Note expired'], user_id => get_csrf_token()};
	}
	my $fh;
	unless (open($fh, '<:utf8', get_upload_dir . $id))
	{
		delete_entry($id);
		response->status(404);
		return template 'index' => {err => ['Note not found'], user_id => get_csrf_token()};
	}
	unless ($db_res->{user_id} == session('user'))
	{
		my $id=session('user');
		my $user = database -> prepare ('SELECT login FROM user where id = (?)');
		$user -> execute ($id);
		$user=$user->fetchrow_hashref();
		unless ($db_res->{friends} =~ /$user->{login}/ && $db_res->{friends} !~ /\w$user->{login}/ 
			&& $db_res->{friends} !~ /$user->{login}\w/)
		{
			return template 'index' => {err => ['Note not found_('], user_id => get_csrf_token()};
		}
	}
	my @text=<$fh>;
	close ($fh);
	for (@text)
	{
		$_= encode_entities ($_, '<>&"');
		s/\t/&nbsp;&nbsp;&nbsp;/g;
		s/^ /&nbsp;/g;
	}
	return template 'paste_show.tt' => {id => $id, text => \@text, 
		raw => join ('',@text), create_time => $db_res->{create_time}, 
		expire_time => $db_res->{expire_time}, title => $db_res->{title}, 
		user_id => get_csrf_token()};
};

get '/auth' => sub {
	#printf "OK, auth!\n";
	set layout => 'noauth';
	template auth => {user_id => get_csrf_token()};
};

get '/' => sub {
	unless (session('user'))
	{
		#printf "redirect to auth\n";
		redirect '/auth';
	}
	set layout => 'main';
    template index => {user_id => get_csrf_token()};
};

post '/auth' => sub {
	my $login = params -> {login};
	printf "OK, $login\n";
	my $password = params -> {password};
	printf "OK, $password\n";
	my @err=();
	if (!$login){
		push @err, 'Empty login!';
	}
	if (!$password){
		push @err, 'Empty password!';
	}
	if ($login =~ /\W/)
	{
		push @err, 'Incorrect login!';
	}
	if ($password =~ /\W/)
	{
		push @err, 'Incorrect password';
	}
	if (@err){
		$login = encode_entities ($login, '<>&"');
		$password = encode_entities ($password, '<>&"');
		return template 'auth' => {login => $login, password => $password, err => \@err, user_id => get_csrf_token()};
	}
	my $ifexist = database -> prepare ('SELECT cast(id as unsigned) as id, login,
		pass FROM user where login = (?)');
	my $create = database -> prepare ('INSERT INTO user (login , pass) VALUES ((?),(?))');
	$ifexist -> execute ($login);
	my $db_res = $ifexist -> fetchrow_hashref ();
	unless ($db_res->{id})
	{
		$create -> execute ($login, $password);
		$ifexist -> execute ($login);
		my $db_res = $ifexist -> fetchrow_hashref();
		session 'user' => $db_res->{id};
		redirect '/';
	}
	else
	{
		unless ($db_res->{pass} eq $password)
		{
			push @err, 'Wrong password!';
		}
	}
	unless (@err)
	{
		session 'user' => $db_res->{id};
		redirect '/';
	}
	return template 'auth' => {login => $login, password => $password, err => \@err, user_id => get_csrf_token()};
};

post '/' => sub {
	unless (session('user')) {
		redirect '/auth';
	}
	my $text = params -> {textpaste};
	my $title = params -> {title}||'';
	my $expire = params -> {expire};
	my $friends = params -> {friends}||'';

	my @err=();
	if (!$text) {
		push @err, 'Empty text';
	}
	if (length($text) > 10240) {
		push @err, 'Text too large';	
	}
	if ($expire =~ /\D/ or $expire < 0 or $expire > 3600 * 24 * 365) {
		push @err, 'Expire more than 365 days or bad format';
	}
	if ($friends =~ /\W/ and $friends !~ /\s/)
	{
		push @err, 'Bad name for friends';
	}
	if (defined $title)
	{
		if ($title =~ /\W/)
		{
			push @err, 'Bad name for title';
		}
	}
	if (@err)
	{
		$text = encode_entities ($text, '<>&"');
		$title = encode_entities ($title, '<>&"');
		$friends = encode_entities ($friends, '<>&"');
		return template 'index' => {text => $text, title => $title, expire => $expire, 
			friends => $friends, err => \@err, user_id => get_csrf_token()};
	}
	my $create_time = time();
	my $expire_time = $expire ? $create_time + $expire : undef;
	my $sth = database->prepare('INSERT INTO paste (id, create_time, 
		expire_time, title, user_id, friends) VALUES 
		(cast(? as signed),from_unixtime(?),from_unixtime(?),(?),(?),(?))');
	my $id = '';
	my $try_count = 10;
	while (!$id or -f get_upload_dir . $id){
		database->do("DELETE FROM paste where id = cast(? as signed);", {}, [$id]) if $id;
		unless (--$try_count) {
			$id = undef;
			last;
		}
		$id = crc64($text.$create_time.$id);
		$id = undef unless $sth->execute($id, $create_time, $expire_time, 
			$title, session('user'), $friends);
	}
	unless ($id) {
		die "Try later";
	}
	my $fh;
	unless (open($fh, '>', get_upload_dir.$id)) {
		die "Internal error ", $!, get_upload_dir.$id;
	}
	print $fh $text;
	close($fh);
	redirect '/' . unpack 'H*', pack 'Q', $id;
};

hook before_template_render => sub {
	my $tokens = shift;
	my $last_paste = database->selectall_arrayref('SELECT cast(paste.id as unsigned) as id, 
		create_time, title, login from paste LEFT JOIN user ON paste.user_id=user.id where 
		(expire_time is null or expire_time > current_timestamp) 
		order by create_time desc limit 10', {Slice => {}});
	for (@$last_paste)
	{
		$_->{title} = encode_entities ($_->{title}, '<>&"');
		$_->{id} = unpack 'H*', pack 'Q', $_->{id};
		$_->{login} = encode_entities ($_->{login}, '<>&"');
	}
	$tokens->{last_paste} = $last_paste;
	
	my $my_paste = database->prepare('SELECT cast(id as unsigned) as id, 
		create_time, title, user_id FROM paste 
		where (expire_time is null or expire_time > current_timestamp) and user_id = (?) order by create_time desc limit 10');
	$my_paste->execute(session('user'));
	my @friends = ();
	while (my $buf = $my_paste->fetchrow_hashref())
	{
		$buf->{title} = encode_entities ($buf->{title}, '<>&"');
		$buf->{id} = unpack 'H*', pack 'Q', $buf->{id};
		push @friends, $buf;
	}
	$tokens->{my_paste} = \@friends;

	my $my_name = database->prepare('SELECT login from user where id = (?)');
	$my_name->execute(session('user'));
	my $me=$my_name->fetchrow_hashref();
	$me->{login} = encode_entities ($me->{login}, '<>&"');
	$tokens->{my_name} = $me; 
};

hook before => sub {
    if ( request->is_post() ) {
        my $csrf_token = param('user_id');
        if ( !$csrf_token || !validate_csrf_token($csrf_token) ) {
            redirect '/';
        }
    }
};


true;
