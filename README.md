# MuFirewall
Scripts to use in firewall system(*nix box)

  Project aims make automate the pfSense firewall system(especially large scale # of pfSenses). With these scripts, pfSenses
can be monitored, logged, some features updatable.
  - It needs to communicate some services in server(It uses curl.) 
  - It includes captiveportal logs, squid access logs etc within syslog.
  - It prepares log to send syslog to use in ELK(Elasticsearch-Logstash-Kibana) stack. It optimizes sending logs to decrease size of logs.(both client and server side)

