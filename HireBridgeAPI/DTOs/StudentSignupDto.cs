using System.ComponentModel.DataAnnotations;
using HireBridgeAPI.Validation;  // your custom validation namespace

namespace HireBridgeAPI.DTOs
{
    public class StudentSignupDto
    {
        [Required(ErrorMessage = "Name is required.")]
        [MaxLength(100, ErrorMessage = "Name cannot be longer than 100 characters.")]
        public string Name { get; set; }

        [Required(ErrorMessage = "Registration number is required.")]
        [MaxLength(15, ErrorMessage = "Registration number cannot be longer than 15 characters.")]
        public string RegistrationNumber { get; set; }

        [Required]
        [EmailValidation]
        public string Email { get; set; }

        [Required(ErrorMessage = "Password is required.")]
        [PasswordValidation]   
        public string Password { get; set; }

        public string FCMToken { get; set; }
    }
}
