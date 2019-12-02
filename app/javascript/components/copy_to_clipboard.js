

const copyToClipboard = () => {
  // find all the copy and paste icons
  const copyBtns = document.querySelectorAll('.fas.fa-copy');

  // in the html each icon has a data-target element, which has the same name as the id of the
  // text area which it want to copy from : e.g. data-target="code-input-command"
  //   <div class="code-row">
  //     <div class="code-copy-icon"><i class="fas fa-copy" data-target="code-input-command"></i></div> (the copy and paste icon)
  //     <textarea class="code-input" rows="5" cols="50" id="code-input-command" spellcheck="false"> (text area to copy and paste, also works with <input type="text" value="stuff to copy">)
  // rails new \
  //   --database postgresql \
  //   --webpack \
  //   -m <%= project_template_url(@project) %> \
  //   <%= @project.name.gsub(/\s+/m, '_').downcase %>
  //     </textarea>
  //   </div>

  // for each copy and paste button button
  copyBtns.forEach(elem => {
    // this finds the text inside the data-target="bla" (would return 'bla')
    let command = elem.dataset.target

    // finds the div with the corresponding id
    let commadToCpy = document.querySelector(`#${command}`);

    // add an event listner to each button
    elem.addEventListener('click', (event) => {
      // this if was to deal with a text input that kept resizing after copying, you can skip to the else
      if (elem.dataset.target === "code-input-link") {
        commadToCpy.select()
        let width = commadToCpy.value.length * 9;
        commadToCpy.style = `width: ${width}px; color: #6C72FA; outline: none;`
        document.execCommand("copy")
      } else {
        // selects the content of the text in the text area / input where there is the stuff I want to copy
        commadToCpy.select()
        // change the style of it (the coloured background)
        commadToCpy.style = "color: #6C72FA; outline: none;"
        // copies the selected text
        document.execCommand("copy")
      }
    });

  })

}

export { copyToClipboard }


// const copyToClipboard = () => {
//   document.addEventListener('click', (event) => {
//     console.log(event.currentTarget);
//   })

// };

// export { copyToClipboard }
// let textarea = document.getElementById("textarea");
//   textarea.select();
//   document.execCommand("copy");
