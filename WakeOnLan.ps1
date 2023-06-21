param (
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$")]
    [String]$MacAddress
)

function Get-MacAddressBytes {
    param (
        [String]$MacAddress
    )
    $macBytes = @()
    $macParts = $MacAddress -split "[:-]"
    foreach ($part in $macParts) {
        $macBytes += [byte]([convert]::ToInt32($part, 16))
    }
    return $macBytes
}

function Send-MagicPacket {
    param (
        [byte[]]$Packet
    )
    $broadcastAddress = [System.Net.IPAddress]::Broadcast
    $port = 9 # 7 and 9 port is default ports for wake on lan

    $udpClient = [System.Net.Sockets.UdpClient]::new()
    $udpClient.Connect($broadcastAddress, $port)
    $udpClient.Send($Packet, $Packet.Length)
    $udpClient.Close()
}

$macBytes = Get-MacAddressBytes -MacAddress $MacAddress
$packetHeader = [byte[]]@(0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF)
$magicPacket = $packetHeader + ($macBytes * 16)
Send-MagicPacket -Packet $magicPacket
