import "bootstrap";
import swal from 'sweetalert';
import gsap from 'gsap';
import TweenMax from 'gsap';
import { copyToClipboard } from "../components/copy_to_clipboard"
import { indexSearch } from "../components/index_search"

import { deviseLink } from "../components/devise_link"
import { githubLink } from "../components/devise_link"
import { githubCheckbox } from "../components/devise_link"
import { checkBoxes } from "../components/devise_link"
import { alertsInfo } from "../components/devise_link"
import { confirmation } from "../components/destroy_confirmation"
import { showSchema } from "../components/schema_loader"


const projectShow = document.querySelector(".projects-show");
if(projectShow) {
  showSchema();
  // deviseLink();
  copyToClipboard();
  // githubLink();
  // githubCheckbox();
  checkBoxes();
  // alertsInfo();
  // resizeBox();
}

const projectIndex = document.querySelector(".projects-index");
if(projectIndex) {
  indexSearch();
  confirmation();
}
