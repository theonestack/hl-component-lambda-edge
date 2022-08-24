require 'yaml'

describe 'compiled component lambda-edge' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/set_version.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/set_version/lambda-edge.compiled.yaml") }

  context "Version" do
    let(:resources) { template["Resources"] }

    it "has Version Resource" do
      expect(resources["example2Version"]).to eq({
        "DeletionPolicy" => "Retain",
        "Properties" => {"FunctionName"=>{"Ref"=>"example"}},
        "Type" => "AWS::Lambda::Version"
      })
    end
  end
  
end