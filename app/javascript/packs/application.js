import "bootstrap";
import { highterjs } from "../plugins/highlight"
import { copyToClipboard } from "../components/copy_to_clipboard"
import { indexSearch } from "../components/index_search"

import { submitDevise } from "../components/submit_devise"

const projectShow = document.querySelector(".projects-show");
if(projectShow) {
  highterjs();
  copyToClipboard();
  submitDevise();
}

const projectIndex = document.querySelector(".projects-index");
if(projectIndex) {
  indexSearch();
}


