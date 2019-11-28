const indexSearch = () => {
  const searchBox = document.querySelector('#index-search-box');
  const projectResults = document.querySelectorAll('.project-result');
  const searchableAreas = document.querySelectorAll('.searchable-area');

  searchBox.addEventListener("keyup", event => {
    let query = searchBox.value
    // document.getElementById("test").innerText.replace("Search","hghgh")

    searchableAreas.forEach(area => {
      if (!area.innerText.match(query)) {
        let result = document.querySelector(`#${area.dataset.target}`);
        result.style = "display:none;";
      } else {
        let result = document.querySelector(`#${area.dataset.target}`);
        result.style = "display:block;";
        let matches = document.querySelectorAll(`.${query}`)
        console.log(matches)
        // matched = area.innerText.match(query);
      }
    });
  });
}


export { indexSearch }
