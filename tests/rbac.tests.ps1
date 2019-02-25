param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$AgentTempDirectory
)

#Invoke-Pester -script @{Path= './*.tests.ps1' ;Parameters = @{Environment = 'saat'}}
Describe 'RBAC Model' {

    Context 'Test Run' {
        It 'Deployment Target Resource Group Exists' {
            Get-AzureRMResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue  | Should Not BeNullOrEmpty
        }
    }

    Context 'Credentials' {
        It 'test-developer has credentials' {
            Test-Path -Path  $AgentTempDirectory/test-developer.json | Should Be $true
        }
    }

    Context 'Developer' {
        It 'It should not have access to services' {
            $chromePath = Join-Path ([Environment]::CurrentDirectory) /tests/interactive-login-bypasser/latest/chrome
            $chrome_process = Start-Process -FilePath $chromePath -ArgumentList "--headless","--disable-gpu","--remote-debugging-port=9222" -PassThru
            npm install
            node index.js $AgentTempDirectory/test-developer.json
            $chrome_process.Kill()

            kubectl get services | Should Throw
        }
    }
}