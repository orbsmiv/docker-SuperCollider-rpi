node {

    def scmVars

    stage('scm-clone') {
        // Note that the checkout is hard-coded to search for Version-3.9* only.
        scmVars = checkout([$class: 'GitSCM', branches: [[name: '*/tags/Version-3.9*']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[refspec: '+refs/tags/*:refs/remotes/origin/tags/*', url: 'https://github.com/supercollider/supercollider/']]])
        echo scmVars.GIT_BRANCH
    }

    // stage('dockerfile-clone') {
    //     dir('docker') {
    //         git "https://github.com/orbsmiv/docker-shairport-sync-rpi.git"
    //     }
    // }

    stage('build-docker-image') {
        def tagName = tagFinder(scmVars.GIT_BRANCH)
        echo tagName
        echo "Building image"
        // def newImage = docker.build("orbsmiv/test-private:${tagName}", "--build-arg VERSION=\"${tagName}\"")
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
