Docker node image to be used for [gutenberg-mobile](https://github.com/wordpress-mobile/gutenberg-mobile).

* Sets up nvm
* Clones current `develop` for [gutenberg-mobile](https://github.com/wordpress-mobile/gutenberg-mobile)
* Runs `npm install`
* Deletes the cloned repo

This will cache the dependencies in `.npm` folder, so running `npm install` for [gutenberg-mobile](https://github.com/wordpress-mobile/gutenberg-mobile) from within a Docker container with this image is faster.

A Buildkite job runs every 24 hours to build and push this image with `latest` tag to our AWS ECR.
