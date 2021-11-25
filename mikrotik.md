



Remove all interfaces except ether1 from default bridge

:global etherid

:for etherid from=2 to=24 step=1 do={ /interface bridge port remove numbers=[find interface="ether$etherid"] }
