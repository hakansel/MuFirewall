#!/usr/local/bin/php -f
<?php

$rel_blocked ="last_blocked";

$tarih = `/bin/date "+%Y%m%d-%H%M%S"`;

$firewall_ip = `/sbin/ifconfig re1 | /usr/bin/grep 'inet ' | /usr/bin/awk '{print $2}'`;
$firewall_ip = chop($firewall_ip, "\n");

$result_count = `/bin/cat /var/squidGuard/log/block.log | grep http | /usr/bin/wc -l`;
$result_count = trim($result_count);

if(file_get_contents($rel_blocked) != null)
{
	$line = file_get_contents($rel_blocked);
	$line = trim($line);
}
else
{
	$line = 1;
}

/* get results line by line */
$blocked_file_arr = array();
if($line < $result_count)
{
	while($line < $result_count)
	{
		$line_result = `/usr/bin/head -n $line /var/squidGuard/log/block.log | /usr/bin/tail -1`;
		if($line_result != null)
		{
			$date = `/usr/bin/head -n $line /var/squidGuard/log/block.log | /usr/bin/tail -1 | /usr/bin/awk '{print $1 "-" $2}'`;
			$date = chop($date, "\n");
			$blocked_site = `/usr/bin/head -n $line /var/squidGuard/log/block.log | /usr/bin/tail -1 | /usr/bin/awk '{print $5}' | grep http`;
			$blocked_site = chop($blocked_site, "\n");
			$blocked_client = `/usr/bin/head -n $line /var/squidGuard/log/block.log | /usr/bin/tail -1 | /usr/bin/awk '{print $6}'`;
			$blocked_client = chop($blocked_client, "/-");
			$blocked_client = chop($blocked_client, "\n");
			$blocked_line_arr = array('blockedClient' => $blocked_client, 'blockedSite' => $blocked_site, 'time' => $date, 'firewallip' => $firewall_ip);
			$blocked_line_json = json_encode($blocked_line_arr);
			array_push($blocked_file_arr, $blocked_line_json);
		}

		$line++;
	}
	echo json_encode($blocked_file_arr);
}
else
{
	$blocked_file_arr = array('result' => "empty");
	echo json_encode($blocked_file_arr);
}

file_put_contents($rel_blocked, $result_count);
exit;

?>
