$(function() {
	var helpSearchTimeoutId;
	var lastHelpSearchPattern;
	$("#pattern").keyup(function()
		{
			var pattern = $(this).val();

			// Prevent redundants searches caused by other non-printing keys
			if(pattern == lastHelpSearchPattern) {
				return;
			}
			lastHelpSearchPattern = pattern;

			clearTimeout(helpSearchTimeoutId);
			helpSearchTimeoutId = setTimeout(
				function()
				{
					var $dimmer = $("#results").closest(".ui.segment").find(".dimmer");
					$dimmer.addClass("active").removeClass("disabled");
					$.post('/search',
						{
							"pattern": pattern
						},
						function(result)
						{
							$("#results").val(result.results);
							var html = '';
							var results = result.results;
							for(var i in results)
							{
								var r = results[i];
								html += '<div class="item">' +
									'<i class="search outline icon"></i>' +
									'<div class="content">' +
									'<div class="header">' + r + '</div>' +
									'</div>' +
									'</div>';
							}

							if(html === '') {
								html = "No results found";
							}

							$("#results").html(html);

							$dimmer.addClass("disabled").removeClass("active");
						}
					);
				},
				300
			);
		}
	);
});