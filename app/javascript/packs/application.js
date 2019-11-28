import "bootstrap";
import { highterjs } from "../plugins/highlight"
import { copyToClipboard } from "../components/copy_to_clipboard"

const projectShow = document.querySelector(".projects-show");
if(projectShow) {
  highterjs();
  copyToClipboard();
}

