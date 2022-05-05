CloudFormation do

  tags = []
  tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
  tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }
  
  extra_tags.each { |key,value| tags << { Key: key, Value: value } } if defined? extra_tags

  functions =  external_parameters.fetch(:functions, {})
  

  functions.each do |function_name, lambda_config|
    policies = []
    lambda_config['policies'].each do |name,policy|
      policies << iam_policy_allow(name,policy['action'],policy['resource'] || '*')
    end if lambda_config.has_key?('policies')

    IAM_Role("#{function_name}Role") do
      AssumeRolePolicyDocument service_role_assume_policy(['edgelambda', 'lambda'])
      Path '/'
      Policies policies if policies.any?
      ManagedPolicyArns external_parameters['managed_policies']
    end

    environment = lambda_config['environment'] || nil
    # Create Lambda function
    Lambda_Function(function_name) do
      Code do
        ZipFile(FnSub(lambda_config['code']))
      end
      Environment(Variables: Hash[environment.collect { |k, v| [k, v] }]) unless environment.nil?
      Handler(lambda_config['handler'] || 'index.handler')
      MemorySize(lambda_config['memory'] || 128)
      Role(FnGetAtt("#{function_name}Role", 'Arn'))
      Runtime(lambda_config['runtime'])
      Timeout(lambda_config['timeout'] || 10)
      if !lambda_config['named'].nil? && lambda_config['named']
        FunctionName(lambda_config['function_name'] || function_name)
      end
      Tags tags
    end

    Lambda_Version("#{function_name}Version") do
      FunctionName Ref(function_name)
    end

    Output("#{function_name}Version") do
      Value Ref("#{function_name}Version")
      Export FnSub("${EnvironmentName}-#{external_parameters[:component_name]}-#{function_name}Version")
    end

  end

end