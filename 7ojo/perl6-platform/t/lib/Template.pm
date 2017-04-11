unit module Template;

sub docker-dockerfile(%project) returns Str is export {
	q{
FROM nginx:alpine
	}.trim;
}

sub html-welcome(%project) returns Str is export {
	qq{
<!DOCTYPE html>
<html>
<head><title>%project<title>\</title></head>
<body>
<h2>Welcome to %project<title>\</h2>
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc in libero dui. Curabitur eget iaculis ex. Nam pellentesque euismod augue, quis porttitor massa facilisis sit amet. Nulla a diam tempus augue pharetra congue.</p>
</body>
</html>
	}.trim;
}

# vim:noexpandtab
