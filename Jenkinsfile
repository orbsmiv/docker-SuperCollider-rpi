node {

    def scmVars

    stage('scm-clone') {
        dir('supercollider') {
            // Note that the checkout is hard-coded to search for Version-3.9* only.
            scmVars = checkout([$class: 'GitSCM', branches: [[name: '*/tags/Version-3.9*']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[refspec: '+refs/tags/*:refs/remotes/origin/tags/*', url: 'https://github.com/supercollider/supercollider/']]])
            echo scmVars.GIT_BRANCH
        }
    }

    // stage('dockerfile-clone') {
    //     dir('docker') {
    //         git "https://github.com/orbsmiv/docker-shairport-sync-rpi.git"
    //     }
    // }

    stage('build-docker-image') {
        sh 'ls -la'
        def tagName = tagFinder(scmVars.GIT_BRANCH)
        echo tagName
        def tagPush = tagPushName(scmVars.GIT_BRANCH)
        echo tagPush
        echo "Building image"
        // def newImage = docker.build("orbsmiv/test-private:${tagPush}", "--build-arg VERSION=\"${tagName}\" .")
        // docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
        //     newImage.push()
        //     newImage.push("latest")
        // }
        // newImage.push()
        // newImage.push("latest")
    }

}

@NonCPS
def tagFinder(text) {
  def matcher = text =~ ".*/(.*)"
  matcher ? matcher[0][1] : null
}

@NonCPS
def tagPushName(text) {
  def matcher = text =~ ".*/Version-(.*)"
  matcher ? matcher[0][1] : null
}
