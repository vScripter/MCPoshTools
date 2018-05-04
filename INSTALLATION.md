## Installation

__Step 1.__ If you obtained the Module as a `.zip` file, start with Step 2, otherwise, start with Step 5

__Step 2.__ Download the Repository as a `.zip` file by expanding the download carrot on the repo page.

<!-- ![](URL to picture) -->

__Step 3.__ Once downloaded, right-click on the .zip file and open the file Properties. If you see an ‘Unblock’ button at the bottom right of the File Properties Window, click that button and close the File Properties window.

__Step 4.__ Extract the contents of the .zip file, which should look similar to the files you see in the root of the rpository.

__Step 5.__ Within the extracted archive of the repository, move the `MCPoshTools` folder to the following PSModule path so it can be used by all users:

    `C:\Program Files\WindowsPowerShell\Modules\`

  - You can generate a list of valid PSModule path locations by running one of the following PowerShell commands (both give the same result):

    `($ENV:PSModulePath).Split(';')`

    `$ENV:PSModulePath –split ‘;’`

  - If the path `C:\Program Files\WindowsPowerShell\Modules` does not exist, manually create the directories. You can run the following command to create them, for you:

    `mkdir 'C:\Program Files\WindowsPowerShell\Modules'`

__Step 6.__ Run the following command to import the module:

  `Import-Module -Name MCPoshTools`


## Appendix

- The module folder structure should look something like this:
```
MCPoshTools\
|--en-US
|--Inputs
|--Private
|--Public
|--MCPoshTools.psd1
|--MCPoshTools.psm1
\--INSTALLATION.md
```
