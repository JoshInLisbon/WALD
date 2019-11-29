const indexSearch = () => {
  const searchBox = document.querySelector('#index-search-box');
  const projectResults = document.querySelectorAll('.project-result');
  const searchableAreas = document.querySelectorAll('.searchable-area');

  searchBox.addEventListener("keyup", event => {
    let query = searchBox.value
    // document.getElementById("test").innerText.replace("Search","hghgh")

    searchableAreas.forEach(area => {
      if (query === "") {
        projectResults.forEach(result => {
          result.style = "display: block;"
        });
        let all_results = document.querySelectorAll(`[data-test]`)
        all_results.forEach(result => {
          result.style = "color: #858C93;"
          if (result.children.length > 0) {
            result.firstElementChild.style = "color:#6C72FA;"
          }
        });
      }
      if (!area.innerText.match(query)) {
        let result = document.querySelector(`#${area.dataset.target}`);
        result.style = "display:none;";

        let non_matches = document.querySelectorAll(`span:not([data-test^=${query}])`);
        non_matches.forEach(match => {
          // match.style = "color:#858C93 !important;"
          if (match.children.length > 0) {
            console.log(match.firstElementChild)
            match.firstElementChild.style = "color:#6C72FA;"
          } else {
            match.style = "color:#858C93;"
          }
        });
      } else {
        let result = document.querySelector(`#${area.dataset.target}`);
        result.style = "display:block;";
        let matches = document.querySelectorAll(`[data-test^=${query}]`)
        matches.forEach(match => {
          if (match.children.length > 0) {
            console.log(match.firstElementChild)
            match.firstElementChild.style = "color:#00db22 !important;"
          } else {
            match.style = "color:#FF5F3F !important;"
          }
        });
        // matched = area.innerText.match(query);
      }
    });
  });
}


export { indexSearch }
