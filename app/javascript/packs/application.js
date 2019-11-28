import "bootstrap";
import { highterjs } from "../plugins/highlight"
import { copyToClipboard } from "../components/copy_to_clipboard"
import { indexSearch } from "../components/index_search"

const projectShow = document.querySelector(".projects-show");
if(projectShow) {
  highterjs();
  copyToClipboard();
}

const projectIndex = document.querySelector(".projects-index");
if(projectIndex) {
  indexSearch();
}

