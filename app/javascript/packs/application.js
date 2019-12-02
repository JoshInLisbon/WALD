import "bootstrap";
import { copyToClipboard } from "../components/copy_to_clipboard"
import { indexSearch } from "../components/index_search"

import { deviseLink } from "../components/devise_link"
import { githubLink } from "../components/devise_link"
import { githubCheckbox } from "../components/devise_link"
import { checkBoxes } from "../components/devise_link"


const projectShow = document.querySelector(".projects-show");
if(projectShow) {
  // deviseLink();
  copyToClipboard();
  // githubLink();
  // githubCheckbox();
  checkBoxes();
}

const projectIndex = document.querySelector(".projects-index");
if(projectIndex) {
  indexSearch();
}


