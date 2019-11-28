const submitDevise = () => {
  const deviseCheckbox = document.querySelector(".devise-checkbox-class")
  deviseCheckbox.addEventListener('change', event => {
    console.log('hello')
  });
  // $(".devise-checkbox-class").on("click", function (){
  //   $(".devise-form-class").submit();
  // });
}

export { submitDevise }
