<?php
$file = '/opt/bitnami/wordpress/wp-config.php';
$content = file_get_contents($file);

// Remove any existing broken proxy lines (lines 2-3 if they contain the bad code)
$lines = explode("\n", $content);
$cleaned = [];
foreach ($lines as $line) {
    if (strpos($line, 'Cloudflare SSL proxy support') !== false) continue;
    if (strpos($line, "isset([") !== false) continue;
    if (strpos($line, "HTTP_X_FORWARDED_PROTO") !== false && strpos($line, '$_SERVER') === false) continue;
    $cleaned[] = $line;
}
$content = implode("\n", $cleaned);

// Insert correct snippet after <?php
$snippet = 'if (isset($_SERVER[\'HTTP_X_FORWARDED_PROTO\']) && $_SERVER[\'HTTP_X_FORWARDED_PROTO\'] === \'https\') { $_SERVER[\'HTTPS\'] = \'on\'; }';
$content = preg_replace('/^<\?php\s*\n/', "<?php\n" . $snippet . "\n", $content);

file_put_contents($file, $content);
echo "Fixed! First 3 lines:\n";
$lines = explode("\n", $content);
for ($i = 0; $i < 3; $i++) echo $lines[$i] . "\n";
