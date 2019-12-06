const showSchema = () => {
  const openSchemaBtn = document.querySelector('#openSchema');
  openSchemaBtn.addEventListener('click', (event) => {
    openIframe();
    loadSchema();
    openSchemaBtn.style = "width: 100%; height: auto;"
    const shutEyes = document.querySelector('.eyes-on');
    const shutEyesHov = document.querySelector('.eyes-hov-on');
    const openEyes = document.querySelector('.eyes-off');
    const openEyesHov = document.querySelector('.eyes-hov-off');
    shutEyes.classList.toggle('imp_d_none');
    shutEyesHov.classList.toggle('imp_d_none');
    openEyes.classList.toggle('imp_d_none');
    // openEyesHov.classList.toggle('imp_d_none');
    openSchemaBtn.classList.toggle('openSchema');
    openSchemaBtn.classList.toggle('openSchemaOpen');
  });

  const loadSchema = (event) => {
    const xmlCode = document.querySelector("#XML-input-command").value;

    const iframe = document.querySelector("iframe");
    const innerDoc = iframe.contentWindow.document;
    const saveLoad = innerDoc.querySelector("#saveload");


    saveLoad.click();
    const loadDb = innerDoc.querySelector("#clientload");
    const textArea = innerDoc.querySelector(".textAreaForXml");

    textArea.value = xmlCode;
    loadDb.click();

    const toggle = innerDoc.querySelector('#toggle');
    toggle.classList.toggle('on');
    toggle.classList.toggle('off');

    const bar = innerDoc.querySelector('#bar');
    bar.style = "overflow: hidden; height: 0px;";
  }

  const openIframe = () => {
  const frame = document.querySelector('.iframe-wrapper')
  if (frame.style.display === "none") {
    frame.style.display = "block";
  } else {
    frame.style.display = "none";
  }
}

}

export { showSchema }
