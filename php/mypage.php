<?php
$service_url = 'http://pythonapi:8080/generate';
$curl = curl_init($service_url);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$curl_response = curl_exec($curl);
if ($curl_response === false) {
    $info = curl_getinfo($curl);
    curl_close($curl);
    die('error occured during curl exec. Additioanl info: ' . var_export($info));
}
curl_close($curl);
$decoded = json_decode($curl_response);
if (isset($decoded->response->status) && $decoded->response->status == 'ERROR') {
    die('error occured: ' . $decoded->response->errormessage);
}
//var_export($decoded->response);
//var_dump($curl_response);
//var_dump($decoded->fortune);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Test Page</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>

<div class="container">
<h1>Api test page</h1>

<p>You should hopefully see something below this</p>

<?php
echo "<p>Your fortune is " .$decoded->fortune."</p>";
?>

