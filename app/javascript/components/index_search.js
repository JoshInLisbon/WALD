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
        });
      }
      if (!area.innerText.match(query)) {
        let result = document.querySelector(`#${area.dataset.target}`);
        result.style = "display:none;";

        let non_matches = document.querySelectorAll(`span:not([data-test^=${query}])`);
        non_matches.forEach(match => {
          match.style = "color:#858C93 !important;"
        });
      } else {
        let result = document.querySelector(`#${area.dataset.target}`);
        result.style = "display:block;";
        let matches = document.querySelectorAll(`[data-test^=${query}]`)
        matches.forEach(match => {
          match.style = "color:#FF5F3F !important;"
        });
        // matched = area.innerText.match(query);
      }
    });
  });
}


export { indexSearch }
