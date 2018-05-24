
// adds listeners that trigger the PIP Update process.
export function addListeners(channel, page=document) {

  page.addEventListener('blur', function(e) {

    if(e.target.classList.contains("pip-input")){
      e.target.style.background = "initial";
    }

    if (e.target !== e.currentTarget) {
      if(e.target.classList.contains("pip-input") && e.target.getAttribute('value') != e.target.value){

        // creates map of values needed for update
        let update_values = {
          "changes": {[e.target.name]: e.target.value},
          "id": e.target.id,
          "hash": e.target.getAttribute("hash"),
          "formatting": e.target.getAttribute("display-type") || null,
          "display_options": e.target.getAttribute("display-options") || null
        };

        // Triggers update event on channel passing in values to the PIP Channel Manager
        channel.push('pip_update', update_values)
        .receive("ok", resp => {
          console.log('phx_in_place: update successful: ', resp, update_values);

          // channel.push("pip:success", {target: e.target, msg: "update successful"});

          // TODO: Could this be done as a channel event instead?
          e.target.dispatchEvent(updateSuccess);
        })
        .receive("error", msg => {
          console.error("phx_in_place: update error: ", msg)
          // Responds with pip:update:event when update fails
          e.target.dispatchEvent(updateError);
        });
      }
      e.stopPropagation();
    }
  }, true);

  page.addEventListener('focus', function(e){
    if(e.target.classList.contains("pip-input")){
      e.target.style.background = "pink";
    }
  }, true);

  page.addEventListener('keydown',function(e){
    if (e.which == 13 && e.target.classList.contains("pip-input")) {
      e.target.blur();
    }
    if(e.which == 9 && e.target.classList.contains("pip-input")) {
      e.preventDefault();
      e.target.blur();
    }
  }, true);

  // Events that are called when updates are run so that a callback to the function
  // can be made
  var updateSuccess = new Event('pip:update:success', {bubbles: true});
  var updateError = new Event('pip:update:error', {bubbles: true});

}
