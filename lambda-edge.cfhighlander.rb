CfhighlanderTemplate do
  
  DependsOn 'lib-iam@0.2.0'
  DependsOn 'lib-ec2@0.2.1'
  
  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', allowedValues: ['development','production'], isGlobal: true
  end
  
  end