node('docker') {
    withCleanup {
        stage name: "Setup Docker Volume", concurrency: 1
        setupDockerVolume('gems')

        wrap([$class: 'TimestamperBuildWrapper']) {
            stage 'Checkout'
            checkout(scm)

            stage 'Setup'
            withDockerCompose { compose ->
                compose.createLocalUser('app')
                compose.execRoot('app', 'chown jenkins:jenkins /gems')

                compose.exec('app', "gem install bundler && bundle install --quiet")

                stage 'Tests'
                try {
                    compose.exec('app', "bundle exec rake ci:spec")
                } finally {
                    publishTestResults()
                }

                stage 'Static Analysis'
                try {
                    compose.exec('app', "bundle exec rake ci:rubocop")
                } finally {
                    publishStyleCheckResults()
                }

                stage 'Cleanup'
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
