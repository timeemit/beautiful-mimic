# beautiful mimic

Imitate beautiful art with your selfies.

## Javascript Sources

To build _bundle.js_:

`babel --presets react src/app --watch --out-file public/javascripts/bundle.js`

To build _react-bundle.js_:

`browserify -t [ babelify --presets [ react ] ] src/react-bundle.js -o public/javascripts/react-bundle.min.js`
