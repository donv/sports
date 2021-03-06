// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery.js
//= require jquery_ujs
//= require bootstrap
//= require moment
//= require moment/nb
//= require bootstrap-datepicker/index
//= require bootstrap-datetimepicker

$(document).ready(function () {
    $('input.date').datepicker({format: "yyyy-mm-dd", autoclose: true});
    // http://eonasdan.github.io/bootstrap-datetimepicker/
    $('input.datetime').datetimepicker({format: "YYYY-MM-DD HH:mm"});
});
