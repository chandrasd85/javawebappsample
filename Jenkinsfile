import groovy.json.JsonSlurper

def getFtpPublishProfile(def publishProfilesJson) {
  def pubProfiles = new JsonSlurper().parseText(publishProfilesJson)
  for (p in pubProfiles)
    if (p['publishMethod'] == 'FTP')
      return [url: p.publishUrl, username: p.userName, password: p.userPWD]
}

node {
  
  withEnv(['AZURE_SUBSCRIPTION_ID=8ca9ed63-23b0-4857-a3c9-461065ace589',
        'AZURE_TENANT_ID=ab8405a0-5976-45b0-a2fe-618c5aeef010']) {
    stage('init') {
      checkout scm
    }
  
    stage('build') {
      sh '/opt/homebrew/bin/mvn clean package'
      
    }
  
    stage('deploy') {
      def resourceGroup = 'cloud-shell-storage-southcentralus'
      def webAppName = 'workshop07042023'
      // login Azure
      withCredentials([usernamePassword(credentialsId: 'Azure-Jenkins', passwordVariable: 'AZURE_CLIENT_SECRET', usernameVariable: 'AZURE_CLIENT_ID')]) {
       sh '''
          az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
          az account set -s $AZURE_SUBSCRIPTION_ID
        '''
      }
      // get publish settings
      def pubProfilesJson = sh script: "az webapp deployment list-publishing-profiles -g $resourceGroup -n $webAppName", returnStdout: true
      def ftpProfile = getFtpPublishProfile pubProfilesJson
      // upload package
      sh "curl -T target/calculator-1.0.war $ftpProfile.url/webapps/ROOT.war -u '$ftpProfile.username:$ftpProfile.password'"
      // log out
      sh 'az logout'
    }
  }
}
