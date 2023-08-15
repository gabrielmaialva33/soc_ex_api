# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SocExApi.Repo.insert!(%SocExApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# create many users
alias SocExApi.Repo
alias SocExApi.Accounts.User

# create 100 users
Enum.map(1..100, fn _ ->
  first_name = Faker.Person.first_name()
  last_name = Faker.Person.last_name()

  %User{
    username: Faker.Internet.user_name(),
    first_name: first_name,
    last_name: last_name,
    email: Faker.Internet.email(),
    password_hash: Argon2.hash_pwd_salt("12345678"),
    avatar_url: "https://api.multiavatar.com/#{first_name}#{last_name}.svg",
    is_online: Faker.random_uniform() > Faker.random_uniform(),
    is_deleted: Faker.random_uniform() < Faker.random_uniform()
  }
  |> Repo.insert!()
end)

# create roles
alias SocExApi.Accounts.Role

Enum.map(["root", "admin", "user"], fn name ->
  %Role{name: name, slug: name |> String.upcase()}
  |> Repo.insert!()
end)

# create user roles
alias SocExApi.Accounts.UserRole

# get all users
users = Repo.all(User)

# get user role
user_role = Role |> Repo.get_by(name: "user")

# attach user role to all users
Enum.map(users, fn user ->
  %UserRole{user_id: user.id, role_id: user_role.id}
  |> Repo.insert!()
end)
