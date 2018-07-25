describe 'provision::powershell' do
  context 'When all attributes are default, on Windows 2012 R2' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    before do
      stub_command('(Get-PackageProvider -Name NuGet -ListAvailable | Where-Object -Property Version -eq 2.8.5.208) -eq $null')
      stub_command('(Get-Module -Name PowerShellGet -ListAvailable | Where-Object -Property Version -eq 1.0.0.1) -eq $null')
      stub_command('(Get-Module -Name PackageManagement -ListAvailable | Where-Object -Property Version -eq 1.0.0.1) -eq $null')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
