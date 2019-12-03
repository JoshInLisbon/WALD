const confirmation = () => {

  const lists = document.querySelectorAll('.delete-icon');

  lists.forEach(deleteButton =>{

    deleteButton.addEventListener("click", event => {
      swal({
        title: "Are you sure?",
        text: "Once deleted, you will not be able to recover this imaginary file!",
        icon: "warning",
        buttons: true,
        dangerMode: true,
      })
      .then((willDelete) => {
        if (willDelete) {
          Rails.ajax({
            url: deleteButton.href,
            type: "DELETE",
            success: swal("BOOM! Your file has been deleted!", {
            icon: "success"})
            })

        } else {
          swal("Your file is safe!");
        }
      });
    });
  })
}

export { confirmation }
