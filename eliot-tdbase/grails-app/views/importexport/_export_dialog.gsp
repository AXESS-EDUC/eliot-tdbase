<%@ page import="org.lilie.services.eliot.tdbase.importexport.Format;" %>
<r:script>
  $(function () {
    $('#export-dialog').dialog({
      resizable: false,
      modal: true,
      buttons: {
        Annuler: function () {
          $(this).dialog("close");
        },
        Exporter: function () {
          var format = $('#export-dialog-form').find("input:radio[name='format-export']:checked").val();

          if(format === '${Format.NATIF_JSON.name()}') {
            window.location = $('#url-format-natif-json').val();
          }
          else if(format === '${Format.MOODLE_XML.name()}') {
            window.location = $('#url-format-moodle-xml').val();
          }

          $(this).dialog("close");
        }
      },
      autoOpen: false
    });
  });

  function actionExporter(urlFormatNatifJson, urlFormatMoodleXml) {
    $('#url-format-natif-json').val(urlFormatNatifJson);
    $('#url-format-moodle-xml').val(urlFormatMoodleXml);

    // Sélection du format natif par défaut
    $('#radio-format-NatifJson').attr('checked', 'checked');

    if (!urlFormatMoodleXml) {
      $('#row-format-MoodleXml').hide();
    }
    else {
      $('#row-format-MoodleXml').show();
    }

    $('#export-dialog').dialog('open');
  }
</r:script>
<div id="export-dialog" title="Export" style="display: none">
  <form id="export-dialog-form">
    <g:hiddenField id="url-format-natif-json" name="url-format-natif-json"/>
    <g:hiddenField id="url-format-moodle-xml" name="url-format-moodle-xml"/>
    <p>Indiquez le format de fichier à exporter :</p>
    <table>
      <tr>
        <td><g:radio id="radio-format-NatifJson" name="format-export" value="${Format.NATIF_JSON.name()}"
                     checked="checked"/>TD Base</td>
      </tr>

      <tr id="row-format-MoodleXml">
        <td><g:radio name="format-export" value="${Format.MOODLE_XML.name()}"/>Moodle</td>
      </tr>
    </table>
  </form>
</div>