## Cleanup 

/system reset-configuration

## Security

#### telnet / serial

/user add name=USER group=full password=PWD

/user remove admin

/ip ssh set strong-crypto=yes

#### ssh
/ip service disable telnet,www,ftp,api,api-ssl,winbox

/ip neighbor discovery-settings set discover-interface-list=none 

/tool mac-server mac-winbox set allowed-interface-list=none

/tool bandwidth-server set enabled=no 

/ip cloud set update-time=yes


## Config

#### Remove all interfaces except ether1 from default bridge

:global etherid

:for etherid from=2 to=24 step=1 do={ /interface bridge port remove numbers=[find interface="ether$etherid"] }

#### create new bridge

/interface bridge add name=br-client

