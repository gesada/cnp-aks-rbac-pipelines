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

    Context 'Developer Role' {

        BeforeAll {
            Set-Location ./tests/interactive-login-bypasser/
            npm install
            node index.js $AgentTempDirectory/test-developer.json
        }

        It 'should not have access to services' {
            kubectl get services --all-namespaces | Should BeNullOrEmpty
        }

        It 'should have access to pods' {
            kubectl get pods --all-namespaces | Should Not BeNullOrEmpty
        }
    }
}