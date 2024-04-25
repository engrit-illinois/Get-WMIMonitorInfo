function Get-VideoOutputTechnology {
    param(
        $Monitor
    )

    $output = $Monitor.VideoOutputTechnology

    switch($output) {
        -2          {"Unassigned"}
        -1          {"Unknown"}
        0           {"VGA"}
        1           {"S-vidio"}
        2           {"Composite Video"}
        3           {"Component Video"}
        4           {"DVI"}
        5           {"HDMI"}
        6           {"LVDS"}
        8           {"D-Jpn"}
        9           {"SDI"}
        10          {"External DisplayPort"}
        11          {"Embedded DisplayPort"}
        12          {"External UDI"}
        13          {"Embedded UDI"}
        14          {"SDTV"}
        15          {"Miracast"}
        16          {"Wired Indirect Display"}
        2147483648  {"Internal Laptop Display"}
        Default     {$output}
    }
    
}