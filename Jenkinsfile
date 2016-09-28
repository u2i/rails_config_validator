node('docker') {
    withCleanup {
        stage name: 'prepare shared volume', concurrency: 1
        sh "(docker volume inspect gems > /dev/null 2>&1) || docker volume create --name=gems"

        wrap([$class: 'TimestamperBuildWrapper']) {
            stage 'checkout'
            checkout(scm)

            stage 'setup docker'
            withDockerCompose { compose ->
                compose.createLocalUser('app')
                compose.execRoot('app', 'chown jenkins:jenkins /gems')

                compose.exec('app', "bundle install --quiet")

                stage 'tests'
                try {
                    compose.exec('app', "bundle exec rake ci:spec")
                } finally {
                    publishTestResults()
                }

                stage 'style'
                try {
                    compose.exec('app', "bundle exec rake ci:rubocop")
                } finally {
                    publishStyleCheckResults()
                }

                stage 'cleanup'
            }
        }
    }
}

def publishTestResults() {
    step([$class: 'JUnitResultArchiver', testResults: 'spec/reports/*.xml,test/reports/*.xml'])
}

def publishStyleCheckResults() {
    step([$class: 'CheckStylePublisher', pattern: 'checkstyle.xml'])
}

def withCleanup(Closure cl) {
    try {
        cl()
    } finally {
        step([$class: 'WsCleanup'])
    }
}
