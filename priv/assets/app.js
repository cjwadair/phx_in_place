"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.addListeners = addListeners;

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

// adds listeners that trigger the PIP Update process.
function addListeners(channel) {
  var page = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : document;


  page.addEventListener('blur', function (e) {

    if (e.target.classList.contains("pip-input")) {
      e.target.style.background = "initial";
    }

    if (e.target !== e.currentTarget) {
      if (e.target.classList.contains("pip-input") && e.target.getAttribute('value') != e.target.value) {

        // creates map of values needed for update
        var update_values = {
          "changes": _defineProperty({}, e.target.name, e.target.value),
          "id": e.target.id,
          "hash": e.target.getAttribute("hash"),
          "formatting": e.target.getAttribute("display-type") || null
        };

        // Triggers update event on channel passing in values to the PIP Channel Manager
        channel.push('pip_update', update_values).receive("ok", function (resp) {
          console.log('received from pip_update', resp["message"], resp["value"], e.target);

          e.target.value = resp['value'];

          // Responds with pip:update:success event when update is successful
          // TODO: Could this be done as a channel event instead?
          e.target.dispatchEvent(updateSuccess);
        }).receive("error", function (msg) {
          console.error("phx_in_place: error updating field: ", msg);
          // Responds with pip:update:event when update fails
          e.target.dispatchEvent(updateError);
        });
      }
      e.stopPropagation();
    }
  }, true);

  page.addEventListener('focus', function (e) {
    if (e.target.classList.contains("pip-input")) {
      e.target.style.background = "pink";
    }
  }, true);

  page.addEventListener('keydown', function (e) {
    if (e.which == 13 && e.target.classList.contains("pip-input")) {
      e.target.blur();
    }
    if (e.which == 9 && e.target.classList.contains("pip-input")) {
      e.preventDefault();
      e.target.blur();
    }
  }, true);

  // Events that are called when updates are run so that a callback to the function
  // can be made
  var updateSuccess = new Event('pip:update:success', { bubbles: true });
  var updateError = new Event('pip:update:error', { bubbles: true });
}
