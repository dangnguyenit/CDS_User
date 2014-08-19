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
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require_tree ./lib/jquery
//= require_tree ./lib/modernizr
//= require_tree ./lib/less-js
//= require_tree ./lib/flot
//= require_tree ./lib/ie
//= require_tree ./lib/jquery-ui
//= require_tree ./lib/jquery-ui-touch-punch
//= require_tree ./lib/slimscroll
//= require_tree ./lib/breakpoints
//= require_tree ./lib/notification
//= require_tree ./lib/select2
//= require_tree ./lib/mutilselect
//= require_tree ./lib/modals
//= require_tree ./lib/boostraps
//= require_tree ./lib/tables
//= require_tree ./lib/boostraps-select
//= require_tree ./lib/fuelux-checkbox
//= require_tree ./lib/bootstrap-datepicker
//= require_tree ./lib/bootstrap-fileupload
//= require_tree ./lib/jquery-validator
//= require_tree ./lib/charts
//= require_tree ./lib/expander
//= require_tree ./lib/fileupload
//= require_tree ./lib/core


//= require i18n
//= require i18n/translations
//= require jMenu
//= require jquery.validate
//= require common_functions

$.fn.dataTableExt.oApi.fnReloadAjax = function(oSettings, sNewSource, fnCallback, bStandingRedraw) {
  if (sNewSource !== undefined && sNewSource !== null) {
    oSettings.sAjaxSource = sNewSource;
  }

  // Server-side processing should just call fnDraw
  if (oSettings.oFeatures.bServerSide) {
    this.fnDraw();
    return;
  }

  this.oApi._fnProcessingDisplay(oSettings, true);
  var that = this;
  var iStart = oSettings._iDisplayStart;
  var aData = [];

  this.oApi._fnServerParams(oSettings, aData);

  oSettings.fnServerData.call(oSettings.oInstance, oSettings.sAjaxSource, aData, function(json) {
    /* Clear the old information from the table */
    that.oApi._fnClearTable(oSettings);

    /* Got the data - add it to the table */
    var aData = (oSettings.sAjaxDataProp !== "") ?
      that.oApi._fnGetObjectDataFn(oSettings.sAjaxDataProp)(json) : json;

    for (var i = 0; i < aData.length; i++) {
      that.oApi._fnAddData(oSettings, aData[i]);
    }

    oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();

    that.fnDraw();

    if (bStandingRedraw === true) {
      oSettings._iDisplayStart = iStart;
      that.oApi._fnCalculateEnd(oSettings);
      that.fnDraw(false);
    }

    that.oApi._fnProcessingDisplay(oSettings, false);

    /* Callback user function - for event handlers etc */
    if (typeof fnCallback == 'function' && fnCallback !== null) {
      fnCallback(oSettings);
    }
  }, oSettings);
};