window.onload = function() {
    var path = window.location.pathname;

    var pageArray = new Array();
    pageArray.push('/app/dashboard/news/new');
    pageArray.push('/app/dashboard/community/new');
    pageArray.push('/app/dashboard/event/new');
    pageArray.push('/app/dashboard/group/post');
    pageArray.push('/app/dashboard/scholarship/new');
    pageArray.push('/app/dashboard/alert/new');
    pageArray.push('/app/dashboard/alert/manage'); // For editing mode purposes

    if (pageArray.indexOf(path) > -1) {
        var converter = new showdown.Converter();
        var pad = document.getElementById('pad');
        var markdownArea = document.getElementById('markdown');

        if (pad != null && markdown != null) {
            pad.addEventListener('keydown',function(e) {
                if(e.keyCode === 9) { // tab was pressed
                    // get caret position/selection
                    var start = this.selectionStart;
                    var end = this.selectionEnd;

                    var target = e.target;
                    var value = target.value;

                    // set textarea value to: text before caret + tab + text after caret
                    target.value = value.substring(0, start)
                        + "\t"
                        + value.substring(end);

                    // put caret at right position again (add one for the tab)
                    this.selectionStart = this.selectionEnd = start + 1;

                    // prevent the focus lose
                    e.preventDefault();
                }
            });

            var previousMarkdownValue;

            // convert text area to markdown html
            var convertTextAreaToMarkdown = function(){
                $.each(jQuery('textarea[data-autoresize]'), function() {
                    var offset = this.offsetHeight - this.clientHeight;

                    var resizeTextarea = function(el) {
                        jQuery(el).css('height', 'auto');
                        jQuery(el).focus();
                    };
                    jQuery(this).on('keyup input', function() { resizeTextarea(this);


                    }).removeAttr('data-autoresize');
                });
                var markdownText = pad.value;
                markdownText = markdownText.replace(/`/g, '');
                previousMarkdownValue = markdownText;
                html = converter.makeHtml(markdownText);
                html = html.replace(/<a href/g, '<a target="_blank" href');
                html = html.replace(/<hr/g, '<hr style="height: 5px; border-top-width: 5px; border-top-style: solid; border-top-color:#000000"');
                html = linkifyHtml(html, {
                    target: '_blank'
                });
                markdownArea.innerHTML = html;
                $("#pad").val(markdownText);
            };

            var didChangeOccur = function(){
                if(previousMarkdownValue != pad.value){
                    return true;
                }
                return false;
            };

            // check every second if the text area has changed
            setInterval(function(){
                if(didChangeOccur()) {
                    convertTextAreaToMarkdown();
                }
            }, 1000);

            // convert textarea on input change

            pad.addEventListener('input', convertTextAreaToMarkdown);

            // convert on page load
            convertTextAreaToMarkdown();
        }
    }
}