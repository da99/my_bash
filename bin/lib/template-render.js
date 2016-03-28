
const ARGS       = process.argv.slice(2);
const Handlebars = require("handlebars");
const Template   = ARGS.pop();
const Data       = ARGS.pop() || "ENV";
const FS         = require("fs");
const PATH       = require("path");


const source   = template_to_string(Template);


const template = Handlebars.compile(source, {strict: true});

var data = data_to_object(Data);

var current = source;
var old     = "";
while (current !== old) {
  old = current;
  current = Handlebars.compile(current, {strict: true})(data);
}

console.log(current);

// ==============================================================================

function data_to_object(Data) {
  if (Data === 'ENV')
    return process.env;

  if (FS.statSync(Data).isFile())
    return JSON.parse(FS.readFileSync(Data).toString());

  // === We assume it's a directory:
  const files = FS.readdirSync(Data);
  var file;
  var data = {};
  for (var i = 0; i < files.length; i++) {
    file = files[i];
    data[file] = FS.readFileSync(PATH.join(Data, file)).toString().trim();
  }

  return data;
} // === function

function template_to_string(FD) {
  return FS.readFileSync(FD).toString();
}

