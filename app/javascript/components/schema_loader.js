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
}

setTimeout(() => {window.onload = loadSchema()}, 1000);

export { loadSchema }
