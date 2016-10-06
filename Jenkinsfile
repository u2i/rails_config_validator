setDockerImageName()
discardOldBuilds()

node('docker') {
    withCleanup {
        stage name: "Setup Docker Volume", concurrency: 1
        setupDockerVolume("gems-${env.EXECUTOR_NUMBER}-ruby-2.3")

        withTimestamps {
            stage 'Checkout'
            checkout(scm)

            stage 'Setup'
            withDockerCompose { compose ->
                stage 'Resolve Dependencies'
                compose.exec('app', "gem install bundler -- --silent --quiet --no-verbose --no-document")
                compose.exec('app', "bundle install --quiet")

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
