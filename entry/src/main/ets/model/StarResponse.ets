import { UserResponse } from './UserResponse'

export interface StarResponse {
  name: string,
  description: string
  owner: UserResponse
}