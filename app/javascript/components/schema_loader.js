const showSchema = () => {
  const openSchemaBtn = document.querySelector('#openSchema');
  openSchemaBtn.addEventListener('click', (event) => {
    openIframe();
    loadSchema();
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
    bar.style = "overflow: hidden; height: 22px;";
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
