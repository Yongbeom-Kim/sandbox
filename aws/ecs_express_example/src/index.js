"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var express = require("express");
var app = express();
console.log(process.env.PORT);
var PORT = process.env.PORT || 80;
app.get('/', function (req, res) {
    res.send('Hello World!');
});
app.listen(PORT, function () {
    console.log("Server is running on port ".concat(PORT));
});
