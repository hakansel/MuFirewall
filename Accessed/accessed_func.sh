#!/usr/local/bin/php -f
<?php

$rel_accessed ="last_accessed";

$max_entry = 300;

$tarih = `/bin/date "+%Y%m%d-%H%M%S"`;

$firewall_ip = `/sbin/ifconfig re1 | /usr/bin/grep 'inet ' | /usr/bin/awk '{print $2}'`;
$firewall_ip = chop($firewall_ip, "\n");

$result_count = `/bin/cat /var/squid/logs/access.log | /usr/bin/wc -l`;
$result_count = trim($result_count);

$access_pro = `ps aux | grep access.log | grep -v grep | wc -l`;

if(file_get_contents($rel_accessed) != null)
{
        $line = file_get_contents($rel_accessed);
        $line = trim($line);
}
else
{
        $line = 1;
}

/* get results line by line */
$accessed_file_arr = array();
if($line < $result_count)
{	if ( $access_pro < "5" )
	{	
        while(($line < $result_count) && ($max_entry > 0))
        {
                $line_result = `/usr/bin/head -n $line /var/squid/logs/access.log | /usr/bin/tail -1`;
                if($line_result != null)
                {
                        $date = `/bin/echo $line_result | /usr/bin/awk '{print $1}'`;
                        $date = chop($date, "\n");
						$date = date("Y-m-dTG:i:s.Z",$date);
                        $accessed_site = `/bin/echo $line_result | /usr/bin/awk '{print $7}'`;
                        $accessed_site = chop($accessed_site, "\n");
                        $accessed_client = `/bin/echo $line_result | /usr/bin/awk '{print $3}'`;
                        $accessed_client = chop($accessed_client, "/-");
                        $accessed_client = chop($accessed_client, "\n");
						$user_name = `/bin/echo $line_result | /usr/bin/awk '{print $8}'`;
						$user_name = chop($user_name, "\n");
						$connection_status = `/bin/echo $line_result | /usr/bin/awk '{print $4}'`;
						$connection_status = chop($connection_status, "\n");
                        $accessed_line_arr = array('connSt' => $connection_status, 'user' => $user_name, 'client' => $accessed_client, 'site' => $accessed_site, 'time' => $date, 'fwip' => $firewall_ip);
                        $accessed_line_json = json_encode($accessed_line_arr);
                        array_push($accessed_file_arr, $accessed_line_json);
                }

                $line++;
				$max_entry--;
        }
        echo json_encode($accessed_file_arr);
	}
}
else
{
        $accessed_file_arr = array();
        echo json_encode($accessed_file_arr);
}

file_put_contents($rel_accessed, $result_count);
exit;

?>