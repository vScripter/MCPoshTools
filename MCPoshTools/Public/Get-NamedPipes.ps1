function Get-NamedPipes {

    [System.IO.Directory]::GetFiles("\\.\\pipe\\")

} # end function Get-NamedPipes