jQuery(document).ready( function(){
  $('button, input:submit').button();
  $('.buttonset').buttonset();
});

function remote_call( opts ) {
  opts.dataType = opts.dataType || 'json';

  opts.beforeSend = function(xhr) {
    $(this).trigger( 'ajax:loading', xhr );
  };
  opts.success = function(data, status, xhr) {
    $(this).trigger( 'ajax:success', [data, status, xhr] );
    if ( opts.repeat ) {
      setTimeout( function(){
        remote_call(opts)
      }, opts.repeat );
    }
  };
  opts.complete = function(xhr) {
    $(this).trigger( 'ajax:complete', xhr );
  };
  opts.error = function(xhr, status, error) {
    $(this).trigger( 'ajax:failure', [xhr, status, error]);
  };

  $.ajax(opts);
}
